﻿using System;

namespace TCMSSH.Common
{
    /// <summary>
    /// Base class for authentication events.
    /// </summary>
    public abstract class AuthenticationEventArgs : EventArgs
    {
        /// <summary>
        /// Gets the username.
        /// </summary>
        public string Username { get; private set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="AuthenticationEventArgs"/> class.
        /// </summary>
        /// <param name="username">The username.</param>
        public AuthenticationEventArgs(string username)
        {
            this.Username = username;
        }
    }
}
