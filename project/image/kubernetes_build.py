#!/usr/bin/env python3
import os, sys, time


def cmd(s, error=True):
    print('RUN ', s)
    sys.stdout.flush()
    t = time.time()
    if os.system(s):
        if error:
            raise RuntimeError("ERROR: failed to run '%s'" % s)
        else:
            print("WARNING: failed running '%s'" % s)
    print("Success running '{s}' -- ({time:0.1f} seconds)".format(
        s=s, time=time.time() - t))


def thread_map(callable, inputs, nb_threads=None):
    if len(inputs) == 0:
        return []
    from multiprocessing.pool import ThreadPool
    tp = ThreadPool(nb_threads or 2)
    return tp.map(callable, inputs)


def fetch():
    # Git the complete remote repo with all branches
    cmd("cd /cocalc && git fetch --all --recurse-submodules")


def checkout():
    # Checkout a particular branch (passed in as an environment variable branch),
    # or if branch is not defined, then checkout origin/master.
    branch = os.environ.get('branch', 'master')
    cmd("cd /cocalc && git fetch --all && git checkout {branch} && git reset --hard origin/{branch}"
        .format(branch=branch))


def build():
    # NOTE: we have to build smc-webapp, which is big, just for a few things shared between
    # frontend and backend involving REDUX/React.  Our code really needs to be refactored.
    def f(path):
        cmd("cd /cocalc/src/{path} && npm ci --progress=false".format(path=path))

    thread_map(f, [
        '',
        'smc-webapp',
        'smc-util-node',
        'smc-util',
        'smc-project',
        'smc-project/jupyter',
        'smc-webapp/jupyter',
    ])
    if not os.path.exists('/cocalc/bin'):
        os.makedirs('/cocalc/bin')
    cmd("pip install --system --upgrade /cocalc/src/smc_pyutil/")
    cmd("pip install --system --upgrade /cocalc/src/smc_sagews/")


def coffee():
    def f(path):
        cmd("coffee -c /cocalc/src/{path}".format(path=path))

    thread_map(f, [
        'smc-webapp',
        'smc-util',
        'smc-util-node',
        'smc-project',
        'smc-project/jupyter',
        'smc-webapp/jupyter',
    ])


def typescript():
    # TODO: currently this errors somewhere in building something in node_modules in smc-webapp, since I can't get
    # tsconfig to just leave that code alone (since it is used?).  Hmm...
    cmd("cd /cocalc/src/smc-project; /cocalc/src/node_modules/.bin/tsc -p tsconfig.json",
        error=False)


def main():
    fetch()
    checkout()
    build()
    typescript()
    coffee()
    print("completely done")
    os._exit(0)  # in case of some weird thread being stuck...

if __name__ == '__main__':
    main()
