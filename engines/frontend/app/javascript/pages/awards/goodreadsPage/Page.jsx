import React from 'react'
import { Card } from 'react-bootstrap'
import PageTemplate from 'pages/templates/booksListYearly/Page'
import ExternalTextLink from 'components/ExternalTextLink'

const TAG_IDS = [240]

const pageConfig = {
  booksListFilter: { tagIds: TAG_IDS },
  SidebarCardWidget: () => (
    <Card className='sidebar-card-widget'>
      <Card.Header className='widget-title'>
        { 'Goodreads Choice awards' }
      </Card.Header>

      <Card.Body>
        <ExternalTextLink
          href='https://www.goodreads.com/choiceawards'
          text='Official site'
        />

        <br />

        <ExternalTextLink
          href='https://en.wikipedia.org/wiki/Goodreads_Choice_Awards'
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
