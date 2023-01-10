## Compiling
Install truffle globally:

```javascript
    npm install --location=global truffle
```
Run npm install in project directory

```javascript
    npm install
```
To compile the Smart Contract:

```solidity
    truffle compile
```
To check the size of the Smart Contract:

```solidity
    truffle run contract-size
```
## Testing
> If you want to start testing with the pre built test units, you could switch to `dev_testing` branch first.
- Run ganache on terminal:

```
    ganache
```

- Copy the mnemonic given from ganache to `.env` file
- Configure the `development` network in `truffle-config.js` file
- Run the test

```
    truffle test
```
