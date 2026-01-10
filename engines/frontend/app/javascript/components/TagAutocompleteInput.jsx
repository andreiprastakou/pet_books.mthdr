import React, { useCallback, useState } from 'react'
import PropTypes from 'prop-types'
import { useSelector } from 'react-redux'
import Autosuggest from 'react-autosuggest'
import classNames from 'classnames'

import { selectTagsRefs } from 'store/tags/selectors'
import { filterByString } from 'utils/filterByString'
import { sortByString } from 'utils/sortByString'

const TagAutocompleteInput = ({ inputProps, onSuggestionSelected }) => {
  const allTags = useSelector(selectTagsRefs())
  const [query, setQuery] = useState('')
  const suggestions = sortByString(
    filterByString(allTags, 'name', query),
    'name'
  )
  const exactMatch = suggestions.find(tag => tag.name === query)
  if (!exactMatch)  suggestions.unshift({ name: query, new: true })

  const handleKeyDown = event => {
    if (['Tab'].includes(event.code))
      event.preventDefault()
  }

  const handleGetSuggestionValue = useCallback(tag => tag.name, [])

  const handleSuggestionSelected = useCallback((_e, { suggestion: tag }) => {
    onSuggestionSelected(tag)
    setQuery('')
  }, [onSuggestionSelected])

  const handleAnythingDoNothing = useCallback(() => null, [])

  const handleRenderSuggestion = useCallback(tag => renderSuggestion(tag, query), [query])

  return (
    <Autosuggest
      containerProps={{ className: 'tags-search-control' }}
      getSuggestionValue={handleGetSuggestionValue}
      inputProps={{
        ...inputProps,
        value: query,
        onChange: (e, { newValue }) => setQuery(newValue),
        className: 'form-control',
        onKeyDown: handleKeyDown
      }}
      onSuggestionSelected={handleSuggestionSelected}
      onSuggestionsClearRequested={handleAnythingDoNothing}
      onSuggestionsFetchRequested={handleAnythingDoNothing}
      renderSuggestion={handleRenderSuggestion}
      suggestions={suggestions}
    />
  )
}

const renderSuggestion = (tag, query) => {
  const classes = classNames(
    'suggestion',
    {
      'exact-match': !tag.new && (tag.name === query),
      'new-tag': tag.new
    }
  )
  return (
    <div className={classes}>
      { tag.name }
    </div>
  )
}

TagAutocompleteInput.propTypes = {
  inputProps: PropTypes.object.isRequired,
  onSuggestionSelected: PropTypes.func.isRequired,
}

export default TagAutocompleteInput
