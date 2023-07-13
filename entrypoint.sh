#!/bin/bash

/aesmd.sh

gramine-sgx-get-token --output node.token --sig node.sig
gramine-sgx node