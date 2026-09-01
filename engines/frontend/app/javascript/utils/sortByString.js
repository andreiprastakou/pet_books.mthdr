import sortBy from 'lodash/sortBy'

export const sortByString = (entries, attributeName) => sortBy(entries, entry => entry[attributeName].toUpperCase())
