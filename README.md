# PRESENT Cipher Implementation and Cryptanalysis

## Overview

This repository contains the implementation and security analysis of the **PRESENT block cipher**, a lightweight cryptographic algorithm designed for resource-constrained devices such as IoT nodes, RFID tags, embedded systems, and wireless sensor networks.

The project explores the design principles of lightweight cryptography through practical implementation, evaluation, and cryptanalytic investigation of the PRESENT cipher.

---

## Features

* Implementation of the PRESENT block cipher
* 80-bit key version
* Encryption and decryption functionality
* Round key generation (key scheduling)
* S-box and permutation layer implementation
* Verification using standard test vectors
* Security analysis and performance evaluation

---

## Technical Background

PRESENT is an ultra-lightweight Substitution-Permutation Network (SPN) block cipher standardized under ISO/IEC 29192-2.

### Cipher Parameters

| Parameter        | Value                                  |
| ---------------- | -------------------------------------- |
| Block Size       | 64 bits                                |
| Key Size         | 80 bits                                |
| Number of Rounds | 31                                     |
| Structure        | SPN (Substitution-Permutation Network) |

The cipher is specifically designed for low-area and low-power hardware implementations while maintaining an adequate security margin.

---

## Learning Objectives

This project was developed to gain practical understanding of:

* Symmetric-key cryptography
* Lightweight cryptographic primitives
* Substitution-Permutation Networks
* Block cipher design principles
* Cryptographic implementation techniques
* Security evaluation of lightweight ciphers

---

## Results

The implementation successfully:

* Generates correct round keys
* Encrypts plaintext according to PRESENT specifications
* Produces outputs matching standard test vectors
* Demonstrates the internal operation of lightweight block ciphers

---

## Applications

PRESENT is widely studied for:

* RFID systems
* Internet of Things (IoT)
* Embedded security
* Wireless sensor networks
* Low-power cryptographic devices

---

## Technologies Used

* Python
* NumPy
* Cryptographic Algorithms
* Lightweight Cryptography

---

## Author

**Bhavya Dixit**
