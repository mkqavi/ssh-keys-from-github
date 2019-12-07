# ssh-keys-from-github

## Usage

To return all SSH keys of a user:

```sh
./add-keys.sh [GitHub username]
```

Add SSH Keys to `authorized_keys`:

```sh
./add-keys.sh [GitHub username] >> $HOME/.ssh/authorized_keys
```
