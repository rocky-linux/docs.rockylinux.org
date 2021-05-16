import * as React from 'react';

/**
 * A wrapper box that constrains the width of the content.
 *
 * @param {boolean} wide Whether or not the box should be wide
 */
const Container = ({ children, wide, ultrawide, noPadTop }) => {
    const widthClass = wide
        ? 'max-w-screen-lg 2xl:px-0'
        : ultrawide
        ? ''
        : 'max-w-screen-lg';
    const paddingTop = noPadTop ? '' : 'pt-10';
    return (
        <div className={`${widthClass} w-full mx-auto px-4 ${paddingTop}`}>
            {children}
        </div>
    );
};

export default Container;
