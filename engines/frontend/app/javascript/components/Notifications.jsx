import React from 'react'
import { connect } from 'react-redux'
import { AlertList } from 'react-bs-notifier'
import PropTypes from 'prop-types'

import { removeMessage } from 'store/notifications/actions'
import { selectMessages } from 'store/notifications/selectors'

class Notifications extends React.Component {
  static propTypes = {
    messages: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number,
    })).isRequired,
    onRemoveMessage: PropTypes.func.isRequired,
  }

  shouldComponentUpdate(nextProps) {
    const { messages } = this.props
    return messages !== nextProps.messages
  }

  handleDismiss = message => {
    const { onRemoveMessage } = this.props
    onRemoveMessage(message.id)
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

const mapDispatchToProps = {
  onRemoveMessage: removeMessage,
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Notifications)
