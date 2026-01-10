import { isArray } from 'lodash'

export const objectToParams = (object, initialParams = '') => {
  const params = new URLSearchParams(initialParams)
  Object.keys(object).forEach(key => {
    const value = object[key]
    if (isArray(value))
      value.forEach(entry => params.append(`${key}[]`, entry))
    else if (value)
      params.set(key, value)
    else
      params.delete(key)
  })
  const query = params.toString()
  return query ? `?${query}` : ''
}
