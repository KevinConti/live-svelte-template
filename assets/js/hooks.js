/**
 * LiveSvelte Hook Implementation
 * 
 * This module provides the integration between Phoenix LiveView and Svelte components.
 * It handles component lifecycle (mounting, updating, destroying) and provides the
 * LiveSvelte context for bi-directional communication.
 */

import * as Components from '../svelte/components/**/*'
import {detach, insert, noop} from 'svelte/internal'

let {default: modules, filenames} = Components

filenames = filenames
    .map(name => name.replace('../svelte/components/', ''))
    .map(name => name.replace('.svelte', ''))

const components = Object.assign({}, ...modules.map((m, index) => ({[filenames[index]]: m.default})))

/**
 * Converts a base64 string to a DOM element
 * @param {string} base64 - Base64 encoded HTML string
 * @returns {HTMLElement} The decoded DOM element
 */
function base64ToElement(base64) {
    let template = document.createElement('div')
    template.innerHTML = atob(base64).trim()
    return template
}

/**
 * Extracts and parses a JSON data attribute from an element
 * @param {string} attributeName - Name of the data attribute
 * @param {HTMLElement} el - Element to extract data from
 * @returns {Object} Parsed JSON data or empty object
 */
function dataAttributeToJson(attributeName, el) {
    const data = el.getAttribute(attributeName)
    return data ? JSON.parse(data) : {}
}

/**
 * Creates slot functions for Svelte components
 * @param {Object} slots - Slot configuration
 * @param {Object} ref - Component reference
 * @returns {Object} Slot functions
 */
function createSlots(slots, ref) {
    const createSlot = (slotName, ref) => {
        let savedTarget, savedAnchor, savedElement
        return () => {
            return {
                getElement() {
                    return base64ToElement(dataAttributeToJson('data-slots', ref.el)[slotName])
                },
                update() {
                    const element = this.getElement()
                    detach(savedElement)
                    insert(savedTarget, element, savedAnchor)
                    savedElement = element
                },
                c: noop,
                m(target, anchor) {
                    const element = this.getElement()
                    savedTarget = target
                    savedAnchor = anchor
                    savedElement = element
                    insert(target, element, anchor)
                },
                d(detaching) {
                    if (detaching) detach(savedElement)
                },
                l: noop,
            }
        }
    }

    return Object.keys(slots).reduce((acc, key) => {
        acc[key] = [createSlot(key, ref)]
        return acc
    }, {})
}

/**
 * Extracts props from component reference
 * @param {Object} ref - Component reference
 * @returns {Object} Component props
 */
function getProps(ref) {
    return dataAttributeToJson('data-props', ref.el)
}

/**
 * Finds slot context in component
 * @param {Object} component - Svelte component instance
 * @returns {Array} Slot context array
 */
function findSlotCtx(component) {
    return component.$$.ctx.find(ctxElement => ctxElement.default)
}

const SvelteComponent = {
    mounted() {
        const name = this.el.getAttribute('data-name')
        if (!name) {
            console.error('Component name not provided')
            return
        }

        const props = getProps(this)
        const slots = dataAttributeToJson('data-slots', this.el)
        const slotCtx = Object.keys(slots).length ? findSlotCtx(this) : undefined

        // Create new component instance
        const Component = window.Components[name]
        if (!Component) {
            console.error(`Component ${name} not found in window.Components`)
            return
        }

        try {
            // Create the LiveSvelte context
            const liveSvelteCtx = {
                pushEvent: (event, payload) => this.pushEvent(event, payload)
            }

            this.component = new Component({
                target: this.el,
                hydrate: true,
                props,
                context: new Map([
                    ['live-svelte', liveSvelteCtx],
                    ...(slotCtx ? [slotCtx] : [])
                ])
            })
        } catch (error) {
            console.error(`Error mounting component ${name}:`, error)
        }
    },

    updated() {
        if (!this.component) return

        try {
            const props = getProps(this)
            const slots = dataAttributeToJson('data-slots', this.el)

            // Update component props
            this.component.$set(props)

            // Update slots if they exist
            if (Object.keys(slots).length) {
                this.component.$set(findSlotCtx(this))
            }
        } catch (error) {
            console.error('Error updating component:', error)
        }
    },

    destroyed() {
        try {
            this.component?.$destroy()
        } catch (error) {
            console.error('Error destroying component:', error)
        }
    }
}

// Export both names for backward compatibility
export default {
    SvelteComponent,
    SvelteHook: SvelteComponent  // Alias for LiveSvelte compatibility
}
