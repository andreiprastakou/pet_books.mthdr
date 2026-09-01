import { configureStore } from '@reduxjs/toolkit'

import axisReducer from 'store/axis/slice'
import metadataReducer from 'store/metadata/slice'
import storeAuthorsReducer from 'store/authors/slice'
import storeBooksReducer from 'store/books/slice'
import storeCoverDesignsReducer from 'store/coverDesigns/slice'
import storeTagsReducer from 'store/tags/slice'
import booksListReducer from 'store/booksList/slice'
import booksYearsReducer from 'store/booksYears/slice'
import notificationsReducer from 'store/notifications/slice'

import imageModalReducer from 'modals/imageFullShow/slice'

import authorsPageReducer from 'pages/authorsPage/slice'

export default configureStore({
  reducer: {
    authorsPage: authorsPageReducer,
    axis: axisReducer,
    booksList: booksListReducer,
    booksYears: booksYearsReducer,
    imageModal: imageModalReducer,
    metadata: metadataReducer,
    notifications: notificationsReducer,
    storeAuthors: storeAuthorsReducer,
    storeBooks: storeBooksReducer,
    storeCoverDesigns: storeCoverDesignsReducer,
    storeTags: storeTagsReducer,
  }
})
