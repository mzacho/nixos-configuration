import subprocess
import sys
import os

DEBUG=False

def get_password(account):
    home = os.environ['HOME']
    path = f'{home}/.password-store/{account}.gpg'
    args = ["gpg", "--quiet", "-d", path]
    if DEBUG:
        print(args)
    return subprocess.check_output(args).decode('utf-8').strip()

def get_bw_password(id_, session):
    return subprocess.check_output(['bw', 'get', 'password', id_, "--session", session]).decode('utf-8')

def readfile(name):
    with open(name, "r", encoding='locale') as f:
        return f.read().strip()

if __name__=="__main__":
    print(get_password(sys.argv[1]))
