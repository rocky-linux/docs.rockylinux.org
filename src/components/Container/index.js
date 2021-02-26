import * as React from 'react';

/**
 * A wrapper box that constrains the width of the content.
 *
 * @param {boolean} wide Whether or not the box should be wide
 */
export default ({ children, wide, ultrawide }) => {
    const widthClass = wide
        ? 'max-w-screen-2xl 2xl:px-0'
        : ultrawide
        ? ''
        : 'max-w-screen-lg';
    return (
        <div className={`${widthClass} w-full mx-auto px-4 pt-10`}>
            {children}
        </div>
    );
};
