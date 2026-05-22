#!/usr/bin/env python

import os, sys
import subprocess as proc
import logging
import argparse

logging.basicConfig(level=logging.WARN, format="[%(name)s] %(levelname)s: %(message)s")
logger = logging.getLogger(os.path.basename(__file__))

def run(cmd):
    """Runs commands in a subshell and returns error messages if there is a problem."""
    p = proc.Popen(cmd, shell=True, stdout=proc.PIPE, stderr=proc.PIPE)
    out, err = p.communicate()

    logger.debug('{}:\n{}'.format(cmd, out))

    if p.returncode != 0:
        logger.error('{} failed with returncode {}.\nSTDERR: {}'.format(cmd, p.returncode, err))
        sys.exit(1)


def main(nrrd_in, nrrd_out):
    """runs unring.m on the input file"""
    matlab_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'matlab')
    cmd = (r"addpath(genpath('{}')); unring('{}','{}')".format(
        matlab_path, nrrd_in, nrrd_out))
    run('matlab -nodisplay -nosplash -r "{}"'.format(cmd))


if __name__ == '__main__':
    logger.info('Starting')

    argparser = argparse.ArgumentParser()
    argparser.add_argument('input', help='DWI NRRD file')
    argparser.add_argument('output', help='Ouput NRRD')
    argparser.add_argument('-v', '--verbose', action="count", help='turns on debug messages')
    args = argparser.parse_args()

    # debug mode
    if args.verbose > 0:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.WARN)

    # ensure output directory exists
    output_dir = os.path.dirname(os.path.abspath(args.output))
    if not os.path.isdir(output_dir):
        logger.error('output directory {} does not exist.'.format(output_dir))
        sys.exit(1)

    main(args.input, args.output)

