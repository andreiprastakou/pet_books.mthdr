const localState = state => state.storeCoverDesigns

export const selectCoverDesigns = () => state => Object.values(localState(state).coverDesigns)

export const selectCoverDesign = id => state => localState(state).coverDesigns[id]
