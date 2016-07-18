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
├── test1.sh
└── test2.sh
```

File names of test cases are required to start with "test" or "run". This can be configured with the `--run-prefix` option.

Each script must be executable. Any programming language is available, but do not forget the shebang.

We can run them with assigning the root path of the test suite. The result is printed on the console.

```
$ ./bin/tt-runner.py  sample/test-simple
1..2

# run test1.sh
test1's output
ok 1 test1.sh # 0.0 sec

# run test2.sh
test2's output
not ok 2 test2.sh # 0.0 sec

# tests = 2
# succeeded = 1
# failed = 1
# skipped = 0
# time = 0.0 sec
```

TT-Runner verifies whether each test succeeded or failed with the exit-code. Therefore, each testing script must return a non-zero exit-code when the test fails.

The output in the stdout is obeying Test Anything Protocol (TAP). We can integrate TT-Runner to Jenkins with Jenkins TAP Plugin.

```
$ ./bin/tree-test-runner.py sample/test-simple 2>/dev/null
1..2
ok 1 test1.sh # 0.0 sec
not ok 2 test2.sh # 0.0 sec
```

### Before / After

Like `@Before` (`@After`) in JUnit4, TT-Runner runs preconditioning (postconditioning) scripts before (after) each test case. A preconditioning (postconditioning) script has a file name starts with "before" or "setup"("after" or "teardown").

```
$ tree sample/test-before-after
sample/test-before-after
├── after.sh
├── before.sh
├── test1.sh
└── test2.sh

$ ./bin/tt-runner.py sample/test-before-after 2>/dev/null
1..6
ok 1 before.sh # 0.0 sec
ok 2 test1.sh # 0.0 sec
ok 3 after.sh # 0.0 sec
ok 4 before.sh # 0.0 sec
ok 5 test2.sh # 0.0 sec
ok 6 after.sh # 0.0 sec
```

Unlike JUnit, the before or after scripts are considered as separated operations from test cases. However, they are not independent. When a before operation fails, the following test cases are skipped.

```
$ ./bin/tt-runner.py sample/test-skip 2>/dev/null
1..3
not ok 1 before.sh # 0.0 sec
ok 2 test.sh # SKIP
# skipped because before.sh did not succeed.
ok 3 after.sh # 0.0 sec
```

Equivalents of `@BeforeClass` (`@AfterClass`) in JUnit4 are also available. Scripts starting with "before-all" or "first" ("after-all" or "last") are run once before (after) all tests in the same directory. They are used for deploying the tested program before testing, for example.

```
$ tree sample/test-before-after-all
sample/test-before-after-all
├── after-all.sh
├── before-all.sh
├── test1.sh
└── test2.sh

$ ./bin/tt-runner.py sample/test-before-after-all 2>/dev/null
1..4
ok 1 before-all.sh # 0.0 sec
ok 2 test1.sh # 0.0 sec
ok 3 test2.sh # 0.0 sec
ok 4 after-all.sh # 0.0 sec
```

The prefixes can be configured with following command line options: `--before-prefix`, `--after-prefix`, `--before-all-prefix` and `--after-all-prefix`.

### Nested tests

Test scripts can be nested. In the other word, they can be tree-structured. In each node, the before / after operations can be defined.

```
sample/test-nest
├── setup
│   └── run.sh
├── teardown
│   └── run.sh
├── test1
│   ├── before.sh
│   ├── run1.sh
│   └── run2.sh
└── test2
    └── run.sh

$ ./bin/tt-runner.py sample/test-nest 2>/dev/null
1..9
ok 1 setup/run.sh # 0.0 sec
ok 2 test2/run.sh # 0.0 sec
ok 3 teardown/run.sh # 0.0 sec
ok 4 setup/run.sh # 0.0 sec
ok 5 test1/before.sh # 0.0 sec
ok 6 test1/run1.sh # 0.0 sec
ok 7 test1/before.sh # 0.0 sec
ok 8 test1/run2.sh # 0.0 sec
ok 9 teardown/run.sh # 0.0 sec
```

Each node in the tree is symmetric. We can gather some test suite under the same directory and can run them at once.

```
$ ./bin/tt-runner.py sample 2>/dev/null
1..24
not ok 1 test-skip/before.sh # 0.0 sec
ok 2 test-skip/test.sh # SKIP
# skipped because test-skip/before.sh did not succeed.
ok 3 test-skip/after.sh # 0.0 sec
ok 4 test-simple/test1.sh # 0.0 sec
not ok 5 test-simple/test2.sh # 0.0 sec
ok 6 test-before-after-all/before-all.sh # 0.0 sec
...
ok 22 test-before-after/before.sh # 0.0 sec
ok 23 test-before-after/test2.sh # 0.0 sec
ok 24 test-before-after/after.sh # 0.0 sec
```

### Randomize the Test's Order

Each test should be independent. For enhancing independency, TT-Runner can randomize the order of running tests with the `--randomize` option. In randomizing mode, TT-Runner shuffles the order of tests in the same directory. The random seed is printed at the tail of the stderr.
```
$ ./bin/tt-runner.py --randomize sample/test-simple
1..2

# run test2.sh
test2's output
not ok 1 test2.sh # 0.0 sec

# run test1.sh
test1's output
ok 2 test1.sh # 0.0 sec

# tests = 2
# succeeded = 1
# failed = 1
# skipped = 0
# time = 0.0 sec
# random-seed = 39207
```

For repeatablity, the random seed can be assigned with the `--random-seed` option.

## Requirement

- Python 2.7

## License

The MIT License
