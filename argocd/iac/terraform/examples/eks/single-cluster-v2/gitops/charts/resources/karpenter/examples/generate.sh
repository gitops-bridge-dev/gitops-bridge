#!/bin/bash
helm template karpenter-nodes ../ -f common.yaml -f nodegroups.yaml -f userdata.yaml > output/output.yaml
