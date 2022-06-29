# Fees

Liquity moves fees around by minting LUSD. We don't have that privilege.  
Instead, we "charge" this debt to the user, and push this fee to the `FeeDistributor` contract. This contract is able to split fees in a determined way to both pay out interest to DAI depositors and also fund the system's development.

The flow is as follows:
```
  +------------------------------+
  |                              |         add debt for required amount + fees
  |   BorrowerOperationsDai      +-----------------+
  |                              |                 |
  +-----------+------------------+                 |
              |                                    |
              |                            +-------v----------------------+
              |DAI transfer                |                              |
              |                            |    TroveManager              |
              |                            |                              |
              +----------------------+     +------------------------------+
              |                      |
              |                      |
     amount required                 | fees
              |                      |
              |                      |
+-------------v------+           +---v-------------------+
|                    |           |                       |
|      User          |           |  FeeDistrubutor       |
|                    |           |                       |
+--------------------+           +-----------+-----------+
                                             |
                                             |
                                             |
                                      +------+--------+
                                      |               |
                       +--------------v---+      +----v-------------------------+
                       |                  |      |                              |
                       |  LendingPool     |      |   DevWallet or stk contract  |
                       |                  |      |                              |
                       +------------------+      +------------------------------+
```