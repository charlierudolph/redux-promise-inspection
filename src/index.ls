{isFSA} = require 'flux-standard-action'
assign = require 'lodash.assign'
defaultsDeep =  require 'lodash.defaultsdeep'


isPromise = (val) -> val and typeof val.then is 'function'


dispatchActions = ({action, config, dispatch, payload, type}) ->
  localAction = assign {}, action,
    payload: assign {}, payload, (config.payloadKeys[type]): true
  globalAction = assign {}, action,
    payload: assign {}, payload, (config.payloadKeys.actionType): action.type
    type: config.globalActionTypes[type]
  dispatch localAction
  dispatch globalAction


middlewareBuilder = (userConfig = {}) ->
  config = defaultsDeep {}, userConfig,
    globalActionTypes:
      fulfilled: 'PROMISE_FULFILLED'
      pending: 'PROMISE_PENDING'
      rejected: 'PROMISE_REJECTED'
    payloadKeys:
      actionType: 'actionType'
      fulfilled: 'fulfilled'
      pending: 'pending'
      reason: 'reason'
      rejected: 'rejected'
      value: 'value'

  ({dispatch}) -> (next) -> (action) ->
    return next(action) unless isFSA(action) and isPromise(action.payload)
    dispatchActions {
      action
      config
      dispatch
      type: 'pending'
    }
    onResolve = (value) ->
      dispatchActions {
        action
        config
        dispatch
        payload: {(config.payloadKeys.value): value}
        type: 'fulfilled'
      }
      value
    onReject = (reason) ->
      dispatchActions {
        action
        config
        dispatch
        payload: {(config.payloadKeys.reason): reason}
        type: 'rejected'
      }
      return Promise.reject(reason)
    action.payload.then onResolve, onReject


module.exports = middlewareBuilder
