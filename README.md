# TT-Runner

A directory structure framework and a runner for testing scripts.

TT-Runner has following features:

- organize test scripts into a tree;
- run before / after operation for each tests like xUnit;
- compatible to Test Anything Protocol.

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
$ ./bin/tt-runner  sample/test-simple
1..2

# run test_ok.sh
test_ok.sh's output
ok 1 test_ok.sh # 0.0 sec

# run test_ng.sh
test_ng's output
not ok 2 test_ng.sh # 0.0 sec

# tests = 2
# succeeded = 1
# failed = 1
# skipped = 0
# time = 0.0 sec
```

TT-Runner verifies whether each test succeeded or failed with the exit-code. Therefore, each testing script must return a non-zero exit-code when the test fails.

Script files must be executable. Unexecutable files are ignored. Any programming language is available, but do not forget the shebang.

The output in the stdout is obeying Test Anything Protocol (TAP). We can integrate TT-Runner to Jenkins with Jenkins TAP Plugin.

```
$ ./bin/tree-test-runner.py sample/test-simple 2>/dev/null
1..2
ok 1 test_ok.sh # 0.0 sec
not ok 2 test_ng.sh # 0.0 sec
```

### Directory structure

TT-Runner runs a test suite in a directory. Executable files and child directories in the directory are called *nodes*. TT-Runner defines six node types:

- test node,
- run node,
- before node,
- after node,
- before-all node,
- after-all node.

They have file names starting with respectively "test", "run", "before", "after", "before-all" and "after-all". These prefixes can be configured with  following command line options: `--test-prefix`, `--run-prefix`, `--before-prefix`, `--after-prefix`, `--before-all-prefix` and `--after-all-prefix`.

Each node can have child nodes as directory entries. That is, the test suite has a tree structure. When a node is executed, the child nodes are executed recursively. By using this, we can gather existing test suites under a one directory and run at once.

### Test node

Test nodes are main test cases.

Each test should be independent. For enhancing independency, TT-Runner can randomize the order of running tests with the `--randomize` option. In randomizing mode, TT-Runner shuffles the order of tests in the same directory. The random seed is printed at the tail of the stderr. For repeatablity, we can assign a random seed.

### Run node

Run nodes are used as children of other node types. Unlike test nodes, run node has sequences. They are run by the ascending order.

We do not recommend that run nodes and other type nodes should be included in the same directory.

### Before / after node

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
ok 1 before1.sh # 0.0 sec
ok 2 before2.sh # 0.0 sec
ok 3 test1.sh # 0.0 sec
ok 4 after2.sh # 0.0 sec
ok 5 after1.sh # 0.0 sec
ok 6 before1.sh # 0.0 sec
ok 7 before2.sh # 0.0 sec
ok 8 test2.sh # 0.0 sec
ok 9 after2.sh # 0.0 sec
ok 10 after1.sh # 0.0 sec
```

Unlike JUnit, the before or after scripts are considered as separated operations from test cases. However, they are not independent. When a before operation fails, the following test cases are skipped.

```
$ ./bin/tt-runner sample/test-skip 2>/dev/null
1..3
not ok 1 before.sh # 0.0 sec
ok 2 test.sh # SKIP
# skipped because before.sh did not succeed.
ok 3 after.sh # 0.0 sec
```

### Before-all / after-all node

Before-all (after-all) nodes are equivalents of `@BeforeClass` (`@AfterClass`) in JUnit4. They are run *once* before (after) all tests in the same directory. They are used for deploying the tested program before testing, for example.

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
ok 1 before-all1.sh # 0.0 sec
ok 2 before-all2.sh # 0.0 sec
ok 3 test1.sh # 0.0 sec
ok 4 test2.sh # 0.0 sec
ok 5 after-all2.sh # 0.0 sec
ok 6 after-all1.sh # 0.0 sec
```

## Requirement

- Python 2.7

## License

The MIT License
