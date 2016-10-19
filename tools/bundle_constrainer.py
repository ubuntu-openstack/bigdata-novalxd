#!/usr/bin/env python
'''
A tool to add or remove constraints in a Juju bundle YAML file.  Useful to
inject MAAS tags, mem, arch or other constraints.
'''

import logging
import optparse
import os
import sys
import yaml

USAGE = '''Usage: %prog [options]

bundle_constrainer
==============================================================================
A tool to add or remove constraints in a Juju bundle YAML file.  Useful to
inject MAAS tags, mem, arch or other constraints.

Default behavior:
  The specified constraint key-value pairs override existing pairs
  when the keys are identical.  If the specified constraints contain
  keys which do not already exist in the bundle, the new ones are
  added and the existing constraint key pairs remain.

  Services with placement ("to:") are ignored altogether.

  Will not overwrite an existing file without -y.

Usage examples:
  Add constraints and overwrite the original file, with debug output:
    %prog -yd -i my.yaml -o my.yaml --constraints "mem=1G tags=dell,intel"

  Remove existing constraints, add new constraints, and overwrite:
    %prog -yr -i my.yaml -o my.yaml --constraints "mem=1G tags=dell"

  Remove all constraints and write to a new bundle yaml file:
    %prog -i old.yaml -o new.yaml --remove-all

  Remove all constraints, excluding the listed services, and overwrite:
    %prog -yr -i my.yaml -o my.yaml -e "ceilometer-agent,neutron-api"
'''

CNSTR = 'constraints'


def read_yaml(the_file):
    '''Returns yaml data from provided file name

    :param the_file: yaml file name to read
    :returns: dictionary of yaml data from file
    '''
    if not os.path.exists(the_file):
        raise ValueError('File not found: {}'.format(the_file))
    with open(the_file) as yaml_file:
        logging.debug('Reading file: {}'.format(the_file))
        data = yaml.safe_load(yaml_file.read())
    return data


def write_yaml(data, the_file):
    '''Save yaml data dictionary to a yaml file

    :param the_file: yaml file name to write
    :returns: dictionary of yaml data to write to file
    '''
    logging.debug('Writing file: {}'.format(the_file))
    with open(the_file, 'w') as yaml_file:
        yaml_file.write(yaml.dump(data, default_flow_style=False))


def constraint_str_dict(constraint_string):
    '''Convert a juju constraint string into a dictionary.'''
    _constraints = {}
    for pair in constraint_string.split():
        key, val = pair.split('=')
        _constraints[key] = val
    return _constraints


def constraint_dict_str(constraint_dict):
    '''Convert a dictionary into a juju constraint string.'''
    _constraint_string = ''
    for key, val in constraint_dict.items():
        _constraint_string = '{} {}={}'.format(_constraint_string, key, val)
    return _constraint_string.strip()


def merge_constraints(org_constraints, new_constraints):
    '''Merge new constraints with original constraints, where new wins.'''
    _constraints = org_constraints.copy()
    _constraints.update(new_constraints)
    return _constraints


def update_constraints(bundle_dict, opts):
    '''Use command line options to mangle the bundle's dictionary data.'''
    if opts.exclude_services:
        exclude_services = opts.exclude_services.split(',')
        logging.info('Excluding services: {}'.format(exclude_services))
    else:
        exclude_services = []

    for target, t_v in bundle_dict.items():
        logging.debug('Target: {}'.format(target))
        for operation, o_v in t_v.items():
            logging.debug('Operation: {}'.format(operation))
            if operation == 'services':
                # NOTE: operation may commonly be: relation, services,
                #       overrides or inherits.
                for service, s_v in o_v.items():
                    logging.debug('Service: {}'.format(service))

                    if 'to' in s_v.keys():
                        logging.info('Skipping {} as it uses placement '
                                     '({}).'.format(service, s_v['to']))
                        continue

                    if CNSTR in s_v.keys():
                        org_constraints = \
                            constraint_str_dict(s_v[CNSTR])
                        logging.info('{} has existing constraints '
                                     '({}).'.format(service, org_constraints))

                        if opts.remove_all and service not in exclude_services:
                            logging.info('Removing existing constraints for '
                                         '{}'.format(service))
                            del bundle_dict[target][operation][service][CNSTR]
                    else:
                        org_constraints = {}

                    if opts.constraints and service not in exclude_services:
                        new_constraints = constraint_str_dict(opts.constraints)
                        merged_constraints = merge_constraints(org_constraints,
                                                               new_constraints)

                        bundle_dict[target][operation][service][CNSTR] = \
                            constraint_dict_str(merged_constraints)

    return bundle_dict


def main():
    '''Define and handle command line parameters
    '''
    # Define command line options
    parser = optparse.OptionParser(USAGE)
    parser.add_option("-d", "--debug",
                      help="Enable debug logging",
                      dest="debug", action="store_true", default=False)
    parser.add_option('-y', '--yes-overwrite',
                      help='Overwrite the output file',
                      dest='overwrite', action='store_true', default=False)
    parser.add_option("-i", "--in-file",
                      help="YAML input (source) file",
                      action="store", type="string", dest="in_file")
    parser.add_option("-o", "--out-file",
                      help="YAML output (destination) file",
                      action="store", type="string", dest="out_file")
    parser.add_option("--constraints",
                      help="Constraints string to force onto service units.",
                      action="store", type="string", dest="constraints")
    parser.add_option("-e", "--exclude-services",
                      help="Comma-separated list of service names to exclude",
                      action="store", type="string", dest="exclude_services")
    parser.add_option("-r", "--remove-all",
                      help="Remove all constraints.",
                      dest="remove_all", action="store_true", default=False)

    params = parser.parse_args()
    (opts, args) = params

    # Handle parameters, inform user
    if opts.debug:
        logging.basicConfig(level=logging.DEBUG)
        logging.info('Logging level set to DEBUG!')
        logging.debug('parse opts: \n{}'.format(
            yaml.dump(vars(opts), default_flow_style=False)))
        logging.debug('arg count: {}'.format(len(args)))
        logging.debug('parse args: {}'.format(args))
    else:
        logging.basicConfig(level=logging.INFO)

    # Validate options
    if not opts.in_file or not opts.out_file:
        parser.print_help()
        sys.exit(1)

    # Validate and process files
    if os.path.isfile(opts.out_file) and opts.overwrite:
        logging.warning('Output file exists and will be '
                        'overwritten: {}'.format(opts.out_file))
    elif os.path.isfile(opts.out_file) and not opts.overwrite:
        logging.warning('Output file exists and will NOT '
                        'be overwritten: {}'.format(opts.out_file))
        raise ValueError('Output file exists, overwrite option not set.')

    if not os.path.isfile(opts.in_file):
        raise ValueError('Input file not found.')

    if not opts.constraints and not opts.remove_all:
        raise ValueError('No action taken.  Specify new constraints '
                         'and/or existing constraint removal.')

    # Read the infile
    org_bundle_dict = read_yaml(opts.in_file)

    # Mangle dict data
    new_bundle_dict = update_constraints(org_bundle_dict, opts)

    # Write the outfile
    write_yaml(new_bundle_dict, opts.out_file)

if __name__ == '__main__':
    main()
