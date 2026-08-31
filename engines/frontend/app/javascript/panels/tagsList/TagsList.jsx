import { sortBy, upperCase } from 'lodash'
import React, { useCallback, useContext, useMemo, useState } from 'react'
import { Card, Dropdown, Form } from 'react-bootstrap'
import { useSelector } from 'react-redux'

import TagBadge from 'components/TagBadge'
import { selectCategories, selectTagsCategoriesIndex } from 'store/tags/selectors'
import UrlStoreContext from 'store/urlStore/Context'

// eslint-disable-next-line max-lines-per-function
const TagsList = () => {
  const categories = sortBy(useSelector(selectCategories()), 'name')
  const tagsByCategories = useSelector(selectTagsCategoriesIndex())
  const { actions: { showTagIndexEntry } } = useContext(UrlStoreContext)
  const [nameFilter, setNameFilter] = useState('')
  const [categoryFilter, setCategoryFilter] = useState('')

  const handleTagClick = useCallback(id => showTagIndexEntry(id), [showTagIndexEntry])
  const handleNameFilterChange = useCallback(event => setNameFilter(event.target.value), [])
  const handleCategoryFilterChange = useCallback(value => () => setCategoryFilter(value), [])
  const handleRenderPostfix = useCallback(tag => () => (
    tag.connectionsCount > 0 ? ` (${tag.connectionsCount})` : null
  ), [])

  const filteredTagsByCategory = useMemo(() => {
    const normalizedNameFilter = nameFilter.trim().toUpperCase()
    const selectedCategoryId = categoryFilter ? parseInt(categoryFilter, 10) : null

    return categories.reduce((result, category) => {
      if (selectedCategoryId && category.id !== selectedCategoryId) return result

      const tags = (tagsByCategories[category.id] || []).filter(tag =>
        !normalizedNameFilter || upperCase(tag.name).includes(normalizedNameFilter)
      )
      if (tags.length > 0) result[category.id] = sortBy(tags, tag => upperCase(tag.name))
      return result
    }, {})
  }, [categories, categoryFilter, nameFilter, tagsByCategories])

  const filteredTagsCount = Object.values(filteredTagsByCategory)
    .reduce((count, tags) => count + tags.length, 0)
  const selectedCategory = categories.find(category => String(category.id) === categoryFilter)

  return (
    <Card
      aria-label='Tags'
      className='tags-list-widget sidebar-card-widget'
    >
      <Card.Header className='widget-title tags-list-widget-header'>
        <span className='tags-list-widget-title'>
          { 'All Tags' }
        </span>

        <span className='tags-list-count-badge'>
          { filteredTagsCount }
        </span>

        <Form.Control
          aria-label='Filter tags by name'
          className='tags-list-name-filter'
          onChange={handleNameFilterChange}
          placeholder='Filter by name'
          type='search'
          value={nameFilter}
        />

        <Dropdown className='tags-list-category-filter'>
          <Dropdown.Toggle variant='secondary'>
            { selectedCategory ? `Category: ${selectedCategory.name}` : 'All categories' }
          </Dropdown.Toggle>

          <Dropdown.Menu>
            <Dropdown.Item
              active={!categoryFilter}
              onClick={handleCategoryFilterChange('')}
            >
              { 'All categories' }
            </Dropdown.Item>

            { categories.map(category => (
              <Dropdown.Item
                active={categoryFilter === String(category.id)}
                key={category.id}
                onClick={handleCategoryFilterChange(String(category.id))}
              >
                { category.name }
              </Dropdown.Item>
            )) }
          </Dropdown.Menu>
        </Dropdown>
      </Card.Header>

      <Card.Body className='tags-list-widget-body'>
        <div className='tags-index-categories'>
          { categories.map(category => {
            const tags = filteredTagsByCategory[category.id]
            if (!tags) return null

            return (
              <div
                className='tags-index-category'
                key={category.id}
              >
                <div className='category-name'>
                  { `Category: ${category.name}` }
                </div>

                <div className='category-contents'>
                  { tags.map(tag => (
                    <div
                      className='tags-index-entry'
                      key={tag.id}
                    >
                      <TagBadge
                        id={tag.id}
                        onClick={handleTagClick}
                        renderPostfix={handleRenderPostfix(tag)}
                        text={tag.name}
                        variant='dark'
                      />
                    </div>
                  )) }
                </div>
              </div>
            )
          }) }
        </div>
      </Card.Body>
    </Card>
  )
}

export default TagsList
