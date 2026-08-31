import React from 'react'
import { Card } from 'react-bootstrap'
import PageTemplate from 'pages/templates/booksListYearly/Page'
import ExternalTextLink from 'components/ExternalTextLink'

const TAG_IDS = [179]

const pageConfig = {
  booksListFilter: { tagIds: TAG_IDS },
  SidebarCardWidget: () => (
    <Card className='panel--widget'>
      <Card.Header className='panel--header'>
        { 'Pulitzer Prize winners' }
      </Card.Header>

      <Card.Body>
        <ExternalTextLink
          href='https://www.pulitzer.org/'
          text='Official site'
        />

        <br />

        <ExternalTextLink
          href='https://en.wikipedia.org/wiki/Pulitzer_Prize'
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
