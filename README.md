# TT-Runner: a testing scripts runner

TT-Runner is a directory structure framework for testing scripts. It can organize legacy testing scripts into a tree, and it can run them as like using modern testing frameworks.

## Usage

### Run tests

Suppose that we have a test-suite below.

```
sample/test-simple
├── test_ng.sh
└── test_ok.sh
```

We can run them with assigning the root path of the test suite. The result is printed on the console.

```
$ ./bin/tt-runner sample/test-simple
1..2

# run test_ng.sh
test_ng's output
not ok 1 test_ng.sh

# run test_ok.sh
test_ok.sh's output
ok 2 test_ok.sh

# operations = 2
# succeeded = 1
# failed = 1
# skipped = 0
# time-taken = 0 [sec]
```

The output in the stdout is obeying Test Anything Protocol (TAP).

```
$ ./bin/tree-test-runner.py sample/test-simple 2>/dev/null
1..2
ok 1 test_ok.sh
not ok 2 test_ng.sh
```

The result is also output to the directory specified with `-o` option.

```
$ ./bin/tt-runner sample/test-simple -o result 1>/dev/null 2>/dev/null
$ ls result
1.test_ng.sh.out  2.test_ok.sh.out  result.txt
```

`*.out` are stdout and stderr of each scripts. `result.txt` is the TAP formatted result.

### Testing scripts

Testing scripts must return a non-zero exit-code when the test fails. TT-Runner verifies whether each test succeeded or failed with the exit-code.

Script files must be executable. Unexecutable files are skipped. Any programming language is available, but do not forget the shebang.

Testing scripts are executed in the directory where they exist. TT-Runner change the working directory internally. If we do not want to change the working directory, we can set `--no-chdir` option.

### Directory structure

TT-Runner runs a test suite in a directory. Executable files and child directories in the directory are called *nodes*. TT-Runner defines six node types:

- test node,
- run node,
- before node,
- after node,
- before-all node,
- after-all node.

TT-Runner classifies node types with file names. Each node has a file name starting with respectively "test", "run", "before", "after", "before-all" and "after-all". These prefixes can be configured with following command line options: `--test-regex`, `--run-regex`, `--before-regex`, `--after-regex`, `--before-all-regex` and `--after-all-regex`.

Each node can have child nodes as directory entries. That is, the test suite has a tree structure. When a node is executed, the child nodes are executed recursively.

#### Test node

Test nodes are main test cases.

Each test case should be independent. For enhancing independency, TT-Runner can randomize the order of running tests with the `--randomize` option. In randomizing mode, TT-Runner shuffles the order of tests in the same directory. The random seed is printed at the tail of the stderr. For repeatablity, we can assign a random seed.

#### Run node

Run nodes are used as children of other node types. Unlike test nodes, run node has sequences. They are run by the ascending order.

We do not recommend that run nodes and other type nodes should be included in the same directory.

#### Before / after node

Before (after) nodes are preconditioning (postconditioning) scripts. They run before (after) each test case like `@Before` (`@After`) in JUnit4.

Before-operations are run as the ascending order, and after-operations are run as the descending order. `beforeX` and `afterX` should form a pair that is, the condition setup in `beforeX` should be cleaned in `afterX`

```
$ tree sample/test-before-after
sample/test-before-after
├── after1.sh
├── after2.sh
├── before1.sh
├── before2.sh
├── test1.sh
└── test2.sh

$ ./bin/tt-runner sample/test-before-after 2>/dev/null
1..10
ok 1 before1.sh
ok 2 before2.sh
ok 3 test1.sh
ok 4 after2.sh
ok 5 after1.sh
ok 6 before1.sh
ok 7 before2.sh
ok 8 test2.sh
ok 9 after2.sh
ok 10 after1.sh
```

Unlike JUnit, the before or after scripts are considered as separated operations from test cases. However, they are not independent. When a before operation fails, the following test cases are skipped.

```
$ ./bin/tt-runner sample/test-skip 2>/dev/null
1..3
not ok 1 before.sh
ok 2 test.sh # SKIP
# skipped because before.sh did not succeed.
ok 3 after.sh
```

#### Before-all / after-all node

Before-all (after-all) nodes are equivalents of `@BeforeClass` (`@AfterClass`) in JUnit4. They are run *once* before (after) all tests in the same directory.

```
$ tree sample/test-before-after-all
sample/test-before-after-all
├── after-all1.sh
├── after-all2.sh
├── before-all1.sh
├── before-all2.sh
├── test1.sh
└── test2.sh

$ ./bin/tt-runner sample/test-before-after-all 2>/dev/null
1..6
ok 1 before-all1.sh
ok 2 before-all2.sh
ok 3 test1.sh
ok 4 test2.sh
ok 5 after-all2.sh
ok 6 after-all1.sh
```

Preconditioning or postconditioning operations in before, after, before-all and after-all nodes should idempotent. We can check idempotency with `--multiply-pre-post` option. With this option, preconditioning or postconditioning operations are run twice.

## Requirement

- Python 2.7

## License

The MIT License
