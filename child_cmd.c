/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   child_cmd.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aarcos <aarcos@student.42.fr>              #+#  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025-05-18 02:46:23 by aarcos            #+#    #+#             */
/*   Updated: 2025-05-18 02:46:23 by aarcos           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex.h"

char    **get_paths_from_envp(char **envp)
{
    int     i;
    char    *path_line;

    i = 0;
    while (envp[i])
    {
        if (ft_strncmp(envp[i], "PATH=", 5) == 0)
        {
            path_line = envp[i] + 5;
            return (ft_split(path_line, ':'));
        }
        i++;
    }
    return (NULL);
}

char *join_path_cmd(char *path, char *cmd)
{
    char    *tmp;
    char    *full_cmd;

    tmp = ft_strjoin(path, "/");
    if(!tmp)
        return (NULL);
    full_cmd = ft_strjoin(tmp, cmd);
    free(tmp);
    return (full_cmd);
}

static void	try_exec_paths(char **paths, char **cmd_args, char **envp)
{
	char	*full_cmd;
	int		i;

	i = 0;
	while (paths && paths[i])
	{
		full_cmd = join_path_cmd(paths[i], cmd_args[0]);
		if (access(full_cmd, X_OK) == 0)
			execve(full_cmd, cmd_args, envp);
		free(full_cmd);
		i++;
	}
}


void	child_cmd(char *cmd, char **envp, int input_fd, int output_fd)
{
	char	**cmd_args;
	char	**paths;

	if (dup2(input_fd, STDIN_FILENO) == -1)
		error_exit("dup2 input");
	if (dup2(output_fd, STDOUT_FILENO) == -1)
		error_exit("dup2 output");
	close(input_fd);
	close(output_fd);
	cmd_args = ft_split(cmd, ' ');
	if (!cmd_args || !cmd_args[0])
		error_exit("cmd parse error");
	if (access(cmd_args[0], X_OK) == 0)
		execve(cmd_args[0], cmd_args, envp);
	paths = get_paths_from_envp(envp);
	try_exec_paths(paths, cmd_args, envp);
	error_exit("command not found");
}
