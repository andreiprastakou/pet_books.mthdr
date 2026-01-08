import { sortBy, upperCase } from 'lodash'
import React, { useCallback, useContext } from 'react'
import { useSelector } from 'react-redux'
import { Col } from 'react-bootstrap'

import Layout from 'pages/Layout'
import PageConfigurer from 'pages/tagsPage/PageConfigurer'
import TagBadge from 'components/TagBadge'
import TagCard from 'sidebar/tagCard/TagCard'
import { selectCurrentTagId } from 'store/axis/selectors'
import { selectCategories, selectTagsCategoriesIndex } from 'store/tags/selectors'
import UrlStoreContext from 'store/urlStore/Context'

const TagsPage = () => {
  const sidebarShown = Boolean(useSelector(selectCurrentTagId()))
  const categories = sortBy(useSelector(selectCategories()), 'name')
  const tagsByCategories = useSelector(selectTagsCategoriesIndex())
  const { actions: { showTagIndexEntry } } = useContext(UrlStoreContext)

  const handleTagClick = useCallback(id => showTagIndexEntry(id), [showTagIndexEntry])

  const handleRenderPostfix = useCallback(tag => () => (
    tag.connectionsCount > 0 ? ` (${tag.connectionsCount})` : null
  ), [])

  return (
    <>
      <PageConfigurer />

      <Layout classes='tags-page'>
        { sidebarShown ? (
          <Col xs={4}>
            <div className='page-sidebar'>
              <TagCard />
            </div>
          </Col>
        ) : null }

        <Col xs={sidebarShown ? 8 : 12}>
          <div className='tags-index-categories'>
            { categories.map(category => {
              const tagsSorted = sortBy(tagsByCategories[category.id], tag => upperCase(tag.name))
              return (
                <div
                  className='tags-index-category'
                  key={category.id}
                >
                  <div className='category-name'>
                    { `Category: ${category.name}` }
                  </div>

                  <div className='category-contents'>
                    { tagsSorted.map(tag => (
                      <div
                        className='tags-index-entry'
                        key={tag.id}
                      >
                        <TagBadge
                          id={tag.id}
                          key={tag.id}
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
            } ) }
          </div>
        </Col>
      </Layout>
    </>
  )
}

export default TagsPage
