#!/bin/bash

API_SOCKET="firecracker.socket"

rm -f "$API_SOCKET"

firecracker --api-sock "$API_SOCKET"
