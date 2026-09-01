const localState = state => state.storeCoverDesigns

export const selectCoverDesign = id => state => localState(state).coverDesigns[id]
