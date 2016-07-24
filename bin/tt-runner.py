#!/usr/bin/env python2

'''
TT-Runner: a directory structure framework and a runner for testing scripts.
'''

import argparse
import copy
import os
import random
import signal
import stat
import subprocess
import sys
import time

# configurations
ROOT_PATH = '.'
COLOR_OUTPUT = False
RANDOMIZE = False
RAND_SEED = 0

TEST_PREFIXES = []
RUN_PREFIXES = []
BEFORE_PREFIXES = []
AFTER_PREFIXES = []
BEFORE_ALL_PREFIXES = []
AFTER_ALL_PREFIXES = []

def parse_args():
    '''
    Parse command line argument and set to the configuration variables.
    '''

    parser = argparse.ArgumentParser(description=
            'A directory structure framework and a runner for testing scripts.')

    parser.add_argument('PATH', nargs=1,
            help='the root path of the testing scripts')

    parser.add_argument('--color', action='store_true',
            help='color output')

    parser.add_argument('--randomize', action='store_true',
            help='randomize the order of running tests')
    parser.add_argument('--random-seed', nargs=1, type=int,
            default=[random.randint(0,65535)],
            help='the random seed. ' +
                 'Ignored when the --randomize option is not set.')

    parser.add_argument('--test-prefix', nargs=1,
            default=['test'],
            help='prefix of main testing scripts. ' +
                 'In default, "test" is specified.')

    parser.add_argument('--run-prefix', nargs=1,
            default=['run'],
            help='prefix of operation scripts. ' +
                 'In default, "run" is specified.')

    parser.add_argument('--before-prefix', nargs=1,
            default=['before'],
            help='prefix of preconditioning scripts ' +
                 'run before each test in the same directory. ' +
                 'In default, "before" is specified.')

    parser.add_argument('--after-prefix', nargs=1,
            default=['after'],
            help='prefix of postconditioning scripts ' +
                 'run after each test in the same directory. ' +
                 'In default, "after" is specified.')

    parser.add_argument('--before-all-prefix', nargs=1,
            default=['before-all'],
            help='prefix of preconditioning scripts ' +
                 'run once before all tests in the same directory. ' +
                 'In default, "before-all" is specified.')

    parser.add_argument('--after-all-prefix', nargs=1,
            default=['after-all'],
            help='prefix of postconditioning scripts ' +
                 'run once after all tests in the same directory. ' +
                 'In default, "after-all" is specified.')

    args = parser.parse_args()

    global ROOT_PATH
    ROOT_PATH = args.PATH[0]

    global COLOR_OUTPUT
    COLOR_OUTPUT = args.color

    global RANDOMIZE
    global RAND_SEED
    RANDOMIZE = args.randomize
    RAND_SEED = args.random_seed[0]
    random.seed(RAND_SEED)

    global TEST_PREFIXES
    global RUN_PREFIXES
    global BEFORE_PREFIXES
    global AFTER_PREFIXES
    global BEFORE_ALL_PREFIXES
    global AFTER_ALL_PREFIXES
    TEST_PREFIXES = args.test_prefix
    RUN_PREFIXES = args.run_prefix
    BEFORE_PREFIXES = args.before_prefix
    AFTER_PREFIXES = args.after_prefix
    BEFORE_ALL_PREFIXES = args.before_all_prefix
    AFTER_ALL_PREFIXES = args.after_all_prefix

class Node():
    '''
    A node of the test script tree.
    '''

    def __init__(self, path, is_executable=False):
        # Path to file.
        self.path = path

        # Child nodes.
        self.tests = []
        self.runs = []
        self.befores = []
        self.afters = []
        self.before_alls = []
        self.after_alls = []

        # True if the node is a executable file.
        self.is_executable = is_executable

    def __repr__(self):
        return 'Node(' + self.path + ')'

    def __str__(self):
        return os.path.relpath(self.path, ROOT_PATH)

    def is_empty(self):
        if (len(self.tests) == 0 and
            len(self.runs) == 0 and
            len(self.befores) == 0 and
            len(self.afters) == 0 and
            len(self.before_alls) == 0 and
            len(self.after_alls) == 0 and
            self.is_executable == False):
            return True
        else:
            return False

RED = '\033[91m'
GREEN = '\033[92m'
YELLOW = '\033[93m'
BLUE = '\033[94m'

def color(color, message):
    if COLOR_OUTPUT:
        END = '\033[0m'
        return color + message + END
    else:
        return message

class Operation():
    '''
    A unit of testing. Represent each executable script file.
    '''

    # Status
    NOT_DONE, SUCCEEDED, FAILED, SKIPPED = range(4)

    def __init__(self, path, depends):
        self.path = path
        self.depends = copy.copy(depends)
        self.status = Operation.NOT_DONE
        self.elapsed = 0.0
        self.message = ''

    def __repr__(self):
        return ('Operation(path=' + self.path +
                ', depends=[' +
                ','.join([str(d) for d in self.depends]) +
                '], status=' + self.status + ')')

    def __str__(self):
        return os.path.relpath(self.path, ROOT_PATH)

    def run(self):
        '''
        Exec this operation.
        The result is set into field variables.
        '''

        # Skip if depending operation did not succeed.
        for depend_op in self.depends:
            assert depend_op.status != Operation.NOT_DONE
            if depend_op.status != Operation.SUCCEEDED:
                self.status = Operation.SKIPPED
                self.message = ('skipped because ' + str(depend_op) +
                                ' did not succeed.')
                return

        print >> sys.stderr, color(BLUE, '')
        print >> sys.stderr, color(BLUE, '# run ' + str(self))

        start = time.time()

        process = None
        try:
            process = subprocess.Popen([self.path],
                    stdout=sys.stderr,
                    stderr=subprocess.STDOUT)
            process.wait()

        except OSError as e:
            # For the case when the script at the path has not shebang.
            self.status = Operation.FAILED
            self.message = ('OSError: ' + str(e) + '\n' +
                            'Is the shebang correct?')
            return

        except KeyboardInterrupt as i:
            process.send_signal(signal.SIGINT)
            process.wait()
            self.message = 'KeyboardInterrupt'

        end = time.time()
        self.elapsed = end - start

        if process.returncode != 0:
            self.status = Operation.FAILED
        else:
            self.status = Operation.SUCCEEDED

def create_tree(path):
    '''
    Return node object that represents the path.
    '''

    def get_child_node(child_path):
        if os.path.isdir(child_path):
            child_node = create_tree(child_path)
            if child_node.is_empty():
                return None
            else:
                return child_node
        else:
            if os.access(child_path, os.R_OK | os.X_OK):
                return Node(child_path, is_executable=True)
            else:
                print >> sys.stderr, color(BLUE,
                        '# ' + child_path + ' is not executable.')
                return None

    def has_prefix(string, prefixes):
        for prefix in prefixes:
            if string.startswith(prefix):
                return True
        return False

    node = Node(path)
    for entry in os.listdir(path):
        child_path = os.path.join(path, entry)

        # If the directory entry has one of prefixes,
        # add it to the child nodes.

        if has_prefix(entry, TEST_PREFIXES):
            child_node = get_child_node(child_path)
            if child_node == None:
                continue
            node.tests.append(child_node)

        elif has_prefix(entry, RUN_PREFIXES):
            child_node = get_child_node(child_path)
            if child_node == None:
                continue
            node.runs.append(child_node)

        # Before-all and after-all prefixes have higher priority
        # than before and after prefixes.
        elif has_prefix(entry, BEFORE_ALL_PREFIXES):
            child_node = get_child_node(child_path)
            if child_node == None:
                continue
            node.before_alls.append(child_node)

        elif has_prefix(entry, AFTER_ALL_PREFIXES):
            child_node = get_child_node(child_path)
            if child_node == None:
                continue
            node.after_alls.append(child_node)

        elif has_prefix(entry, BEFORE_PREFIXES):
            child_node = get_child_node(child_path)
            if child_node == None:
                continue
            node.befores.append(child_node)

        elif has_prefix(entry, AFTER_PREFIXES):
            child_node = get_child_node(child_path)
            if child_node == None:
                continue
            node.afters.append(child_node)

    return node

def create_plan(root_node):
    '''
    Return a list of operations.
    '''

    def randomize_nodes(in_nodes):
        if not RANDOMIZE:
            return in_nodes
        out_nodes = copy.copy(in_nodes)
        random.shuffle(out_nodes)
        return out_nodes

    def sorted_nodes(in_nodes):
        return sorted(in_nodes, key=lambda node: node.path)

    def revsorted_nodes(in_nodes):
        return sorted(in_nodes, key=lambda node: node.path, reverse=True)

    def visit(node, depends):
        '''
        Visit nodes recursively and return the list of operations
        under the node.
        '''

        # Tree is end.
        if node.is_executable:
            op = Operation(node.path, depends)
            return [op]

        before_all_ops = []
        for before_all_node in sorted_nodes(node.before_alls):
            ops = visit(before_all_node, depends)
            before_all_ops.extend(ops)

        after_all_ops= []
        for after_all_node in revsorted_nodes(node.after_alls):
            ops = visit(after_all_node, depends)
            after_all_ops.extend(ops)

        # Operations depended by other operations.
        my_depends = copy.copy(depends)
        # Before, after and run, test operations
        # depends on before-all operations.
        my_depends.extend(before_all_ops)

        before_ops = []
        for before_node in sorted_nodes(node.befores):
            ops = visit(before_node, my_depends)
            before_ops.extend(ops)

        after_ops= []
        for after_node in revsorted_nodes(node.afters):
            ops = visit(after_node, my_depends)
            after_ops.extend(ops)

        # Run-operations depends on before-all and before operations.
        my_depends.extend(before_ops)

        # Operations in the nodes under this node.
        # It includes all of before-all, before, run, after, after-all.
        ops_under_node = []

        ops_under_node.extend(before_all_ops)

        if len(node.runs) > 0:
            ops_under_node.extend(before_ops)
            for run_node in sorted_nodes(node.runs):
                run_ops = visit(run_node, my_depends)
                ops_under_node.extend(run_ops)
            ops_under_node.extend(after_ops)

        for test_node in randomize_nodes(node.tests):
            ops_under_node.extend(before_ops)

            run_ops = visit(test_node, my_depends)
            ops_under_node.extend(run_ops)

            ops_under_node.extend(after_ops)

        ops_under_node.extend(after_all_ops)

        return ops_under_node

    depends = []
    return visit(root_node, depends)

def run_ops(operations):

    num_ops = len(operations)
    print color(GREEN, '1..' + str(num_ops))

    for i in range(1, num_ops + 1):
        op = operations[i - 1]
        op.run()

        # Format message
        message = ''
        if op.message != '':
            message = '\n' + '\n'.join(
                  ['# ' + line for line in op.message.splitlines()])

        if op.status == Operation.SUCCEEDED:
            print color(GREEN,
                'ok {0:d} {1:s} # {2:.1f} sec'.format(i, op, op.elapsed) +
                message)

        elif op.status == Operation.FAILED:
            print color(RED,
                'not ok {0:d} {1:s} # {2:.1f} sec'.format(i, op, op.elapsed) +
                message)

        elif op.status == Operation.SKIPPED:
            print color(YELLOW,
                'ok ' + str(i) + ' ' + str(op) + ' # SKIP' +
                message)

        else:
            assert False

def summarize(operations):
    '''
    Print the summary of operations.
    Return False if one or more operations are failed.
    '''

    num_test = len(operations)
    num_sunceeded = len(filter(
        lambda o : o.status == Operation.SUCCEEDED, operations))
    num_failed = len(filter(
        lambda o : o.status == Operation.FAILED, operations))
    num_skipped = len(filter(
        lambda o : o.status  == Operation.SKIPPED, operations))
    elapsed = sum([ o.elapsed for o in operations ])

    message = ('\n' +
               '# tests = ' + str(num_test) + '\n' +
               '# succeeded = ' + str(num_sunceeded) + '\n' +
               '# failed = ' + str(num_failed) + '\n' +
               '# skipped = ' + str(num_skipped) + '\n' +
               '# time = {0:.1f} sec'.format(elapsed))

    if RANDOMIZE:
        message += '\n# random-seed = {0:d}'.format(RAND_SEED)

    print >> sys.stderr, color(BLUE, message)

    if num_failed > 0:
        return False
    else:
        return True

if __name__ == '__main__':
    parse_args()
    root_node = create_tree(ROOT_PATH)
    operations = create_plan(root_node)
    run_ops(operations)
    is_success = summarize(operations)
    if not is_success:
        sys.exit(1)
