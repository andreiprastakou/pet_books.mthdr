import { sortBy } from 'lodash'

export const sortByString = (entries, attributeName) => sortBy(entries, entry => entry[attributeName].toUpperCase())
