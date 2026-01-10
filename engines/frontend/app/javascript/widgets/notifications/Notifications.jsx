import React from 'react'
import { connect } from 'react-redux'
import { AlertList } from 'react-bs-notifier'
import PropTypes from 'prop-types'

import { removeMessage } from 'widgets/notifications/actions'
import { selectMessages } from 'widgets/notifications/selectors'

class Notifications extends React.Component {
  static propTypes = {
    messages: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number,
    })).isRequired
  }

  shouldComponentUpdate(nextProps) {
    const { messages } = this.props
    return messages !== nextProps.messages
  }

  handleDismiss = message => {
    removeMessage(message.id)
  }

  render() {
    const { messages } = this.props

    return (
      <AlertList
        alerts={messages}
        dismissTitle='Close'
        onDismiss={this.handleDismiss}
        position='top-right'
        timeout={5000}
      />
    )
  }
}

const mapStateToProps = state => ({
  messages: selectMessages()(state),
})

const mapDispatchToProps = {}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Notifications)
