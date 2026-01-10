const localState = state => state.storeTags

export const selectCoverDesigns = () => state => Object.values(localState(state).coverDesigns)

export const selectCoverDesign = id => state => localState(state).coverDesigns[id]
