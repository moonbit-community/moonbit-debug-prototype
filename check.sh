#!/bin/bash

cd debug_deriving
moon fmt && moon info && moon check && moon test
cd ..

cd debug_deriving_examples
moon fmt && moon info && moon check && moon test
cd ..

cd debug 
moon fmt && moon info && moon check && moon test
cd ..