#!/usr/bin/env bash

source ~/lib/sqlite-helpers

sqlite3 -line $db "delete from $t;"

