# TT-Runner: A Testing Scripts Runner

[![Build Status](https://travis-ci.org/fjkz/tt-runner.svg?branch=master)](https://travis-ci.org/fjkz/tt-runner)

*TT-Runner* is a directory structure framework of testing scripts. Testing scripts are organized into a directory by the determined structure. TT-Runner runs the scripts by the order automatically planed by file names. The testing result is output with [TAP (Test Anything Protocol)](http://testanything.org/).

## Usage

### Running Tests

Suppose that we have testing scripts below. We later describe a set of testing scripts run by TT-Runner as a test suite.

```
sample/test-simple
├── test_not_ok.sh
└── test_ok.sh
```

We can run them by invoking `tt-runner` with the root path of the test suite. If all the testing scripts succeed, `tt-runner` exits with a 0 status code. If there are any failures, `tt-runner` exits with a 1 status code.

The result is printed on the console. The standard out obeys TAP.

```
$ tt-runner sample/test-simple
1..2
not ok 1 test_not_ok.sh
ok 2 test_ok.sh
---
operations       : 2
succeeded        : 1
failed           : 1
skipped          : 0
time taken [sec] : 0

FAILURE

- 1 test_not_ok.sh

```

If we set `--color` option, the console output is colored.

The result is also output to the directory specified with `-o` option. `result.txt` is the TAP formatted result. `*.out` are the standard out and the standard error of each script.

```
$ tt-runner sample/test-simple -o result 1>/dev/null 2>/dev/null
$ ls result
1.test_not_ok.sh.out  2.test_ok.sh.out  result.txt
```

### Writing Scripts

Any programming languages are available for writing scripts. Each script needs to satisfy the following conditions.

Script files must be executable in Unix. That is, they must have readable and executable permission. Unexecutable scripts are skipped. And, do not forget the shebang (a header starting with `#!`).

Testing scripts must exit with a non-zero status code when it fails. `tt-runner` verifies whether each script succeeded or failed with the status code.

Note that each scripts is executed in the directory where it exists. `tt-runner` changes the working directory internally when it runs a script. If you do not want to change the working directory, you can set `--no-change-dir` option.

The following environment variables are assigned when scripts are run.

- `TT_RUNNER_EXEC_DIR` has the working directory path where `tt-runner` is executed.
- `TT_RUNNER_ROOT_DIR` has the root directory path of the test suite.
- `TT_RUNNER_OUTPUT_DIR` has the directory path where the test result will be put.

### Directory Structure

We describe the naming rule and the directory structure that test suites must satisfy.

Files and directories in a test suite are called *nodes*. Six node types are defined:

- test nodes,
- run nodes,
- before nodes,
- after nodes,
- init nodes,
- final nodes.

Node types are classified with file names. File names of each node type start with respectively `test`, `run`, `before`, `after`, `init` and `final`. These prefixes can be configured with the following command line options: `--test-regex`, `--run-regex`, `--before-regex`, `--after-regex`, `--init-regex` and `--final-regex`.

Each node can have child nodes as directory entries. When a node is executed, the child nodes are executed recursively.

#### Test Nodes

Test nodes are main test cases.

Test nodes in the same directory have no order. Each test case should be independent. See the section of "Enhancing the quality of test suites".

#### Run Nodes

Run nodes are used as children of other node types. Unlike test nodes, run nodes have sequence. They are run by the ascending order.

We do not recommend that run nodes and other type nodes should be included in the same directory.

#### Before / After Nodes

Before (After) nodes are preconditioning (postconditioning) scripts. They run before (After) each test node like `@Before` (`@After`) in JUnit4.

Before nodes are run as the ascending order, and after nodes are run as the descending order.

The following is an example.

```
$ tree sample/test-before-after
sample/test-before-after
├── after1.sh
├── after2.sh
├── before1.sh
├── before2.sh
├── test1.sh
└── test2.sh

$ tt-runner sample/test-before-after 2>/dev/null
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

Note that when a preconditioning operation fails the following tests are skipped.

#### Init / Final Nodes

Init (Final) nodes are run once before (after) all tests in the same directory. They are equivalents of `@BeforeClass` (`@AfterClass`) in JUnit4.

Like before nodes and after nodes, init nodes are run as the ascending order and final nodes are run as the descending order.

The following is an example.

```
$ tree sample/test-init-final
sample/test-init-final
├── final1.sh
├── final2.sh
├── init1.sh
├── init2.sh
├── test1.sh
└── test2.sh

$ tt-runner sample/test-init-final 2>/dev/null
1..6
ok 1 init1.sh
ok 2 init2.sh
ok 3 test1.sh
ok 4 test2.sh
ok 5 final2.sh
ok 6 final1.sh
```

## Testing of Test Suites

The following command line options are available for testing of test suites.

- `--print-log` option prints output of running scripts on the console.
- `--stop-on-failure` option skips remaining operations if a operation fails. The postconditioning is also skipped then.
- `--skip-all` option skips all operations. We can know the execution plan and the ID number of each operation.
- `--only` option runs only operations that have specified ID numbers. Note that preconditioning and postconditioning are not automatically executed.
- `--skip` option skips operations that have specified ID numbers.

## Enhancing the Quality of Test Suites

Each test should be independent. For enhancing independency, `tt-runner` randomizes the order of running tests with `--randomize` option. `tt-runner` shuffles the order of tests in the same directory. The random seed is printed at the summary message. We can assign a random seed with `--randomize` option for repeatablity.

Preconditioning operations should be idempotent. We can check idempotency with `--multiply-preconditioning` option. This option runs preconditioning operations twice in a row. Note that postconditioning operations do not need to be idempotent because they should expect preconditions are satisfied.

## Requirement

- Linux
- Python 2.7

## License

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a>

This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
