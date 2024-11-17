# Updating Gettext Configuration

## Current Issue
The following deprecation warning was observed:
```
warning: defining a Gettext backend by calling

    use Gettext, otp_app: ...

is deprecated. To define a backend, call:

    use Gettext.Backend, otp_app: :my_app

Then, instead of importing your backend, call this in your module:

    use Gettext, backend: MyApp.Gettext
```

## Required Changes

1. Locate the Gettext configuration in `lib/ux_express_web/gettext.ex`
2. Update the Gettext backend definition:
   - Replace `use Gettext, otp_app: :ux_express` with:
     ```elixir
     use Gettext.Backend, otp_app: :ux_express
     ```
3. Update any modules that import the Gettext backend:
   - Find files that use `import UxExpressWeb.Gettext`
   - Replace with `use Gettext, backend: UxExpressWeb.Gettext`

## Steps to Verify
1. After making changes, recompile the project:
   ```shell
   mix compile
   ```
2. Verify that the Gettext deprecation warning is no longer present
3. Run tests to ensure translations still work:
   ```shell
   mix test
   ```

## Additional Notes
- This change is part of Gettext's move towards a more explicit and maintainable backend system
- The change is backwards compatible but addresses deprecation warnings
- No changes to actual translations or locale files are needed
