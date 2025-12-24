#!/bin/bash

cd auto_derive  
moon fmt && moon info && moon check && moon test
cd ..

cd auto_derive_example
moon fmt && moon info && moon check && moon test
cd ..

cd debug 
moon fmt && moon info && moon check && moon test
cd ..