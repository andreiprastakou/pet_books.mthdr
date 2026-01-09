import React, { useCallback } from 'react'
import PropTypes from 'prop-types'
import { useDispatch, useSelector } from 'react-redux'
import classnames from 'classnames'

import { selectCurrentBookRef } from 'store/books/selectors'
import {
  selectBookShiftDirectionHorizontal,
  selectDisplayedBookIdsInYear,
} from 'widgets/booksListYearly/selectors'
import {
  setBookShiftDirectionHorizontal,
} from 'widgets/booksListYearly/actions'

import PopularityChart from 'widgets/booksListYearly/components/PopularityChart'
import BookIndexEntry from 'widgets/booksListYearly/components/BookIndexEntry'
import ImageContainer from 'components/ImageContainer'

/* eslint-disable max-len */
const YEAR_BACKGROUNDS = {
  2022: 'https://ichef.bbci.co.uk/news/976/cpsprodpb/1279E/production/_125287657_hi076130836.jpg',
  2021: 'https://edition.cnn.com/interactive/2021/specials/year-in-pictures/media/august/s_DB144887CF3CD01375AECCD53541DB9BF6FFAD6A584BC234851AD45425D38FCE_1636681662106_205-AP21228596468540.jpg.JPG',
  2020: 'https://cdn.cnn.com/cnn/interactive/2020/specials/year-in-pictures/media/yip-2020/s_1C4D1591CADC57205E88CF17E0B735562AA29A2AA6A546E3AA530EF47972F419_1607438039590_278.jpg',

  2019: 'https://cdn.cnn.com/cnn/interactive/2019/12/specials/year-in-pictures/media/images/s_64a163f16ecbb099e52f2f8271f73cbbfcfc9034be4d646f7375e4db1ca6f3d7_1573591331029_ap_19172850559559.jpg',
  2018: 'https://edition.cnn.com/interactive/2018/12/specials/year-in-pictures/media/images/yip2018/68news.jpg',
  2017: 'https://i.cdn.turner.com/cnn/interactive/2017/12/specials/year-in-pictures/media/images/yip2017/123_121_121_AP_17317476459105.jpg',
  2016: 'https://i0.wp.com/newspack-berkeleyside-cityside.s3.amazonaws.com/wp-content/uploads/2017/08/BI6A0286-1.jpg?fit=800%2C533&ssl=1',
  2015: 'https://static01.nyt.com/images/2015/12/27/sunday-review/2015-YIP-JULY-slide-S7CG/2015-YIP-JULY-slide-S7CG-jumbo.jpg',
  2014: 'https://ichef.bbci.co.uk/news/976/mcs/media/images/79743000/jpg/_79743898_rtr3lywf.jpg',
  2013: 'https://www.cnet.com/a/img/resize/a85b9a146ec14e89e0729ff626c71a2381a55cdc/hub/2013/12/06/7fb73e42-7678-11e3-a3c1-14feb5ca9861/image-gallery-02._V367569984_.jpeg?auto=webp&width=1200',
  2012: 'https://cdn.theatlantic.com/thumbor/YZ7UIbJEFB11IGfJ_u821ZKSXW8=/1200x967/media/img/photo/2012/12/2012-the-year-in-photos-part-1-of-3/y45_31010706/original.jpg',
  2011: 'https://i.guim.co.uk/img/static/sys-images/Guardian/Pix/pictures/2011/12/23/1324663295005/Riot-Breaks-Out-After-Gam-007.jpg?width=1010&quality=85&auto=format&fit=max&s=890d81bb827a6fff3eb38f8e114d1299',
  2010: 'https://s4.reutersmedia.net/resources/r/?m=02&d=20101208&t=2&i=270273541&w=780&fh=&fw=&ll=&pl=&sq=&r=2010-12-08T225647Z_01_GM1E63O018F01_RTRRPP_0_SAFRICA-PROTESTS',

  1919: 'https://149359429.v2.pressablecdn.com/wp-content/uploads/2012/06/Emma-Goldman-Union_Square.jpg',
  1918: 'https://i.guim.co.uk/img/media/80cc28f99e794d7a49769f2ea8a95c72b0a3c5e6/1_324_2986_1792/master/2986.jpg?width=1300&quality=85&fit=max&s=2df992a99d0ff1529e619ad3654b311f',
  1917: 'https://jordanrussiacenter.org/wp-content/uploads/2017/08/1917-Lecture-Series-Image.jpg',
  1916: 'https://www.nam.ac.uk/sites/default/files/2018-04/76308_half.jpg',
  1915: 'https://img4.goodfon.com/wallpaper/nbig/6/af/1915-i-god-ssha-bereg-more-pliazh-liudi-retro.jpg',
  1914: 'https://assetsnffrgf-a.akamaihd.net/assets/m/302014025/univ/art/302014025_univ_lsr_xl.jpg',
  1913: 'http://cdn.viewing.nyc/assets/media/fa8baadb4daaddb6145e0eca5b95ec26/elements/4dc1047d3dc8d0e63bd8e12e4813fec4/9df3a02a-c80a-4a61-a3cf-490b7ae83133.jpg',
  1912: 'https://d3d00swyhr67nd.cloudfront.net/w550/collection/NI/NMNI/NI_NMNI_HOYFM_HW_H1722-001.jpg',
  1911: 'https://takemeback.to/static/img/year/1911.jpg',

  1910: 'https://c8.alamy.com/comp/CRCK8G/the-womens-franchise-demonstration-london-1910-from-the-year-1910-CRCK8G.jpg',
  1909: 'https://img4.goodfon.com/wallpaper/nbig/f/df/1909-i-god-ssha-buffalo-doma-obelisk-retro.jpg',
  1908: 'https://th-thumbnailer.cdn-si-edu.com/OjN_CtyeAdvTKnQ6w1wminT75q4=/fit-in/1600x0/https://tf-cmsv2-smithsonianmag-media.s3.amazonaws.com/filer/1908_book_jan08_main_631.jpg',
}
/* eslint-enable max-len */

const YearRow = props => {
  const { year } = props
  const currentBookRef = useSelector(selectCurrentBookRef())
  const displayedBookIds = useSelector(selectDisplayedBookIdsInYear(year))
  const yearIsCurrent = year === currentBookRef.year
  const direction = useSelector(selectBookShiftDirectionHorizontal())
  const dispatch = useDispatch()

  const onAnimationEnd = useCallback(e => {
    if (e.animationName === 'move-left' || e.animationName === 'move-right')
      dispatch(setBookShiftDirectionHorizontal(null))
  }, [])

  const yearBackgroundUrl = YEAR_BACKGROUNDS[year]

  return (
    <div className={classnames('list-year', { 'current': yearIsCurrent })}>
      { yearIsCurrent && yearBackgroundUrl ? (
        <ImageContainer
          className='background'
          styles={{ backgroundSize: 'cover' }}
          url={yearBackgroundUrl}
        />
      ) : null}

      { yearIsCurrent ? <PopularityChart bookIds={displayedBookIds} /> : null}

      <div className='year-number'>
        { year }
      </div>

      <div
        className={
          classnames('year-books', {
            'shifted-left': yearIsCurrent && direction === 'right',
            'shifted-right': yearIsCurrent && direction === 'left',
          })
        }
        onAnimationEnd={onAnimationEnd}
      >
        { displayedBookIds.map(bookId =>
          (<BookIndexEntry
            id={bookId}
            key={[bookId, direction].join()}
           />)
        ) }
      </div>
    </div>
  )
}

YearRow.propTypes = {
  year: PropTypes.number.isRequired,
}

export default YearRow
