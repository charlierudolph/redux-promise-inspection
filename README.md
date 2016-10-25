# Redux Promise Inspection Middleware

## Installation

```
$ npm install --save redux-promise-inspection-middleware
```

## Usage

```js
import {createStore, applyMiddleware} from 'redux';
import reduxPromiseInspectionMiddleware from 'redux-promise-inspection-middleware';

const promiseMiddleware = reduxPromiseInspectionMiddleware()
const store = createStore(/*...*/, applyMiddleware(promiseMiddleware));
```

## Examples

For actions which are a [flux standard action]() where the payload is a promise if dispatches the following actions
```js
dispatch({
  type: 'MY_ACTION'
  payload: Promise.resolve()
})

// Immediately dispatches the two following actions
{
  type: "MY_ACTION"
  payload: {pending: true}
}

{
  type: "PROMISE_PENDING"
  payload: {
    actionType: 'MY_ACTION',
  }
}


// If the promise resolves (with 'value') it dispatches the two following actions
{
  type: "MY_ACTION"
  payload: {fulfilled: true, value: 'value'}
}

{
  type: "PROMISE_FULFILLED"
  payload: {actionType: 'MY_ACTION', value: 'value'}}
}


// If the promise rejects (with 'error') it dispatches the two following actions
{
  type: "MY_ACTION"
  payload: {rejected: true, reason: 'error'}
}

{
  type: "PROMISE_REJECTED"
  payload: {actionType: 'MY_ACTION', reason: 'error'}}
}
```

## Configuration

The default configuration is
```js
{
  globalActionTypes: {
    fulfilled: 'PROMISE_FULFILLED',
    pending: 'PROMISE_PENDING',
    rejected: 'PROMISE_REJECTED'
  },
  payloadKeys: {
    actionType: 'actionType'
    fulfilled: 'fulfilled',
    pending: 'pending',
    rejected: 'rejected',
    value: 'value'
    reason: 'reason'
  }
}
```

An example of overriding the configuration is as follows:

```js
const promiseMiddleware = reduxPromiseInspectionMiddleware({
  globalActionTypes: {
    fulfilled: 'promise/fulfilled'
    pending: 'promise/pending'
    rejected: 'promise/rejected'
  },
  payloadKeys: {
    value: 'result'
    reason: 'error'
  }
})
```
