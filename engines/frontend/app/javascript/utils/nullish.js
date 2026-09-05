/* eslint-disable eqeqeq, no-eq-null -- intentional nullish (== null) checks */

export const isNullish = value => value == null

export const notNullish = value => value != null
