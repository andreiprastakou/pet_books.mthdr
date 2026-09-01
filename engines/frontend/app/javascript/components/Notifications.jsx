import React, { useCallback } from 'react'
import { connect } from 'react-redux'
import { Alert } from 'react-bootstrap'
import PropTypes from 'prop-types'

import { removeMessage } from 'store/notifications/actions'
import { selectMessages } from 'store/notifications/selectors'

const NotificationAlert = ({ message, onDismiss }) => {
  const handleDismiss = useCallback(() => {
    onDismiss(message.id)
  }, [message.id, onDismiss])

  return (
    <Alert
      dismissible
      onClose={handleDismiss}
      variant={message.type}
    >
      { message.message }
    </Alert>
  )
}

NotificationAlert.propTypes = {
  message: PropTypes.shape({
    id: PropTypes.number.isRequired,
    message: PropTypes.string.isRequired,
    type: PropTypes.string.isRequired,
  }).isRequired,
  onDismiss: PropTypes.func.isRequired,
}

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
      <div className='notifications position-fixed top-0 end-0 p-3'>
        { messages.map(message => (
          <NotificationAlert
            key={message.id}
            message={message}
            onDismiss={this.handleDismiss}
          />
        )) }
      </div>
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
