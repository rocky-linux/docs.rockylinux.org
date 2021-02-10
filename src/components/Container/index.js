import * as React from 'react';

/**
 * A wrapper box that constrains the width of the content.
 *
 * @param {boolean} wide Whether or not the box should be wide
 */
export default ({ children, wide }) => {
    const widthClass = wide ? 'max-w-screen-2xl' : 'max-w-screen-lg';
    return (
        <div className={`${widthClass} w-full mx-auto px-4 pt-10 2xl:px-0`}>
            {children}
        </div>
    );
};
