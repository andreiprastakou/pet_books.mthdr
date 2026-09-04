const localState = state => state.storeCoverDesigns

export const selectCoverDesign = id => state => localState(state).coverDesigns[id]

export const selectCoverDesignsLoaded = () => state => localState(state).coverDesignsLoaded
