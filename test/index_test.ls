require! {
  '../src': promiseInspectionMiddleware
  'redux-mock-store': {default: configureStore}
  bluebird: {coroutine}: Promise
}

describe 'redux promise inspection middleware' ->
  describe 'with default config' ->
    beforeEach ->
      middleware = promiseInspectionMiddleware()
      @store = configureStore([middleware])()

    describe 'without flux standard action promise' ->
      beforeEach coroutine ->*
        @store.dispatch type: 'MY_ACTION'

      specify 'sends the proper actions' ->
        expect(@store.getActions()).to.eql [{type: "MY_ACTION"}]

    describe 'with flux standard action promise that resolves' ->
      beforeEach coroutine ->*
        try
          @result = yield @store.dispatch type: 'MY_ACTION', payload: Promise.resolve(1)
        catch error
          @error = error

      specify 'dispatch call returns promise' ->
        expect(@result).to.eql 1

      specify 'sends the proper actions' ->
        expect(@store.getActions()).to.eql [
          {payload: {pending: true}, type: "MY_ACTION"}
          {payload: {actionType: 'MY_ACTION'}, type: "PROMISE_PENDING"}
          {payload: {fulfilled: true, value: 1}, type: "MY_ACTION"}
          {payload: {actionType: 'MY_ACTION', value: 1}, type: "PROMISE_FULFILLED"}
        ]

    describe 'with flux standard action promise that rejects' ->
      beforeEach coroutine ->*
        @reason = new Error 'invalid'
        try
          @result = yield @store.dispatch type: 'MY_ACTION', payload: Promise.reject(@reason)
        catch error
          @error = error

      specify 'dispatch call returns promise' ->
        expect(@error).to.eql @reason

      specify 'sends the proper actions' ->
        expect(@store.getActions()).to.eql [
          {payload: {pending: true}, type: "MY_ACTION"}
          {payload: {actionType: 'MY_ACTION'}, type: "PROMISE_PENDING"}
          {payload: {rejected: true, @reason}, type: "MY_ACTION"}
          {payload: {actionType: 'MY_ACTION', @reason}, type: "PROMISE_REJECTED"}
        ]

  describe 'with user config' ->
    beforeEach ->
      middleware = promiseInspectionMiddleware(
        globalActionTypes:
          fulfilled: 'promiseInspections/success'
          pending: 'promiseInspections/loading'
          rejected: 'promiseInspections/failed'
        payloadKeys:
          actionType: 'promise'
          fulfilled: 'success'
          pending: 'loading'
          reason: 'error'
          rejected: 'failed'
          value: 'result'
      )
      @store = configureStore([middleware])()

    describe 'without flux standard action promise' ->
      beforeEach coroutine ->*
        @store.dispatch type: 'MY_ACTION'

      specify 'sends the proper actions' ->
        expect(@store.getActions()).to.eql [{type: "MY_ACTION"}]

    describe 'with flux standard action promise that resolves' ->
      beforeEach coroutine ->*
        try
          @result = yield @store.dispatch type: 'MY_ACTION', payload: Promise.resolve(1)
        catch error
          @error = error

      specify 'dispatch call returns promise' ->
        expect(@result).to.eql 1

      specify 'sends the proper actions' ->
        expect(@store.getActions()).to.eql [
          {payload: {loading: true}, type: "MY_ACTION"}
          {payload: {promise: 'MY_ACTION'}, type: "promiseInspections/loading"}
          {payload: {success: true, result: 1}, type: "MY_ACTION"}
          {payload: {promise: 'MY_ACTION', result: 1}, type: "promiseInspections/success"}
        ]

    describe 'with flux standard action promise that rejects' ->
      beforeEach coroutine ->*
        @reason = new Error 'invalid'
        try
          @result = yield @store.dispatch type: 'MY_ACTION', payload: Promise.reject(@reason)
        catch error
          @error = error

      specify 'dispatch call returns promise' ->
        expect(@error).to.eql @reason

      specify 'sends the proper actions' ->
        expect(@store.getActions()).to.eql [
          {payload: {loading: true}, type: "MY_ACTION"}
          {payload: {promise: 'MY_ACTION'}, type: "promiseInspections/loading"}
          {payload: {failed: true, error: @reason}, type: "MY_ACTION"}
          {payload: {promise: 'MY_ACTION', error: @reason}, type: "promiseInspections/failed"}
        ]
