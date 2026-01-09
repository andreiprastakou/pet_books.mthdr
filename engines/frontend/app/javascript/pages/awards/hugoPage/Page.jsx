import React from 'react'
import { Card } from 'react-bootstrap'
import PageTemplate from 'pages/templates/booksListYearly/Page'
import ExternalTextLink from 'components/ExternalTextLink'

const TAG_IDS = [29, 181]

const pageConfig = {
  booksListFilter: { tagIds: TAG_IDS },
  SidebarCardWidget: () => (
    <Card className='sidebar-card-widget'>
      <Card.Header className='widget-title'>
        { 'Hugo awards' }
      </Card.Header>

      <Card.Body>
        <ExternalTextLink
          href='https://www.thehugoawards.org/'
          text='Official site'
        />

        <br />

        <ExternalTextLink
          href='https://en.wikipedia.org/wiki/Hugo_Award_for_Best_Novel'
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
