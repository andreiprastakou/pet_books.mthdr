import { difference, uniq } from 'lodash'
import { pickNearEntries } from 'utils/pickNearEntries'
import { selectYearsReversed } from 'widgets/booksListYearly/selectors'

const localState = state => state.booksListYearlyRefs

export const selectYearsInLoading = () => state => localState(state).yearsInLoading

export const selectYearsLoaded = () => state => localState(state).yearsLoaded

export const selectYearsToLoad = () => state => localState(state).yearsToLoad

export const pickYearsToLoad = year => state => {
  const { yearsToLoad, yearsInLoading, yearsLoaded } = localState(state)
  const allYears = selectYearsReversed()(state)
  const yearsNearer = pickNearEntries(allYears, year, { lengthBefore: 2, lengthAfter: 2, looped: false })
  const yearsFarther = pickNearEntries(allYears, year, { lengthBefore: 5, lengthAfter: 5, looped: false })

  const yearsNearerNotLoaded = difference(yearsNearer, [...yearsInLoading, ...yearsLoaded])
  if (yearsNearerNotLoaded.length === 0) return [...yearsToLoad]

  return uniq([
    ...yearsToLoad,
    ...difference(yearsFarther, [...yearsInLoading, ...yearsLoaded])
  ])
}
