#!/bin/sh

set -e

LUA_PATH="../src/?.lua;$LUA_PATH" lua test.lua
