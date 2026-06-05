### sockH3lix
sockH3lix is a semi-untethered jailbreak for iOS 10.0-10.3.4 designed to be fast.

### Why not doubleH3lix?
While doubleH3lix is an old and time-proven utility, it uses ineffective `v0rtex` exploit to obtain `tfp0`. Alternatively, sockH3lix features `sock_port` exploit, which is known for very high success rate (approximately 90%) and rapid execution.

Also, this tool is fully compatible with doubleH3lix, which means you can change between them without reinstallation.

### Additional changes
sockH3lix offers some useful kernel patches and features missing from doubleH3lix.

* AArch32 support:
    * ARMv7 rudimentary support.
    * Therefore, implement `libpatchfinder32`.
    * Note ARMv7 build is not currently supported by the Makefile.

* System patches:
    * Remove a patch that fully disables the sandbox for any process; instead, patch only what is needed.
    * Allow `host_get_special_port(4)` simultaneously with `task_for_pid(0)`.

* Quality-of-Life changes:
    * Call uicache at sockH3lix app with `sock_port` exploit for sandbox escaping.
    * Smaller but useful codebase changes to reduce system calls count and increase stability.

### License
While doubleH3lix had copyright ambiguity due to the missing `LICENSE` file, it's licensed under the LGPLv2.1 license for now.
