import React from 'react'
import { Card } from 'react-bootstrap'
import PageTemplate from 'pages/templates/booksListYearly/Page'
import ExternalTextLink from 'components/ExternalTextLink'

const TAG_IDS = [248]

const pageConfig = {
  booksListFilter: { tagIds: TAG_IDS },
  SidebarCardWidget: () => (
    <Card className='sidebar-card-widget'>
      <Card.Header className='widget-title'>
        { 'The New York Times Best Sellers' }
      </Card.Header>

      <Card.Body>
        <ExternalTextLink
          href='https://www.nytimes.com/books/best-sellers/'
          text='Official site'
        />

        <br />

        <ExternalTextLink
          href='https://en.wikipedia.org/wiki/The_New_York_Times_Best_Seller_list'
          text='Wiki'
        />
      </Card.Body>
    </Card>
  ),
}

const Page = () => (
  <PageTemplate config={pageConfig} />
)

export default Page
