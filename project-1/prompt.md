# Prompt for BMAD-Method Agents

## Goal

Create a **React**-based web **Calculator** application and deploy it using **docker-compose**.

---

## Requirements

1. **Features**
   - Support basic arithmetic: addition, subtraction, multiplication, and division.
   - Display calculation results in real time.
   - Support both keyboard input and button clicks.

2. **Technology**
   - Frontend: React (latest version).
   - Development environment: Node.js 24+.
   - Create `docker-compose.yml` containing:
     - React app container.
     - Optional Nginx container to serve static files.

3. **Architecture**
   - Use a component-based structure.
   - Implement React hooks (`useState`, `useEffect`).
   - Styling can use simple Tailwind CSS or styled-components.

4. **Documentation**
   - `README.md`: instructions for building and running the project.
   - `Dockerfile`: build image for the React app.
   - `docker-compose.yml`: one-command startup configuration.

5. **MVP features**
   - Scientific functions (e.g., trigonometry, logarithms).
   - Programmer-focused functions (e.g., HEX/BIN conversions).
   - Unit or currency conversions.
   - Traditional memory functions (M+, M-, MR), as the history panel provides a more advanced alternative.
   - User accounts or saving history between visits.
   - Themes or other customization options.

---

## BMAD-Method Role Instructions

- **Analyst**: Verify that the requirements are complete and fill in any gaps.
- **Architect**: Design the React structure and the Docker / docker-compose architecture diagram.
- **PM / PO**: Write brief user stories and define priorities.
- **Developer**: Implement the React calculator, `Dockerfile`, and `docker-compose.yml`.
- **QA**: Provide test plans including basic unit tests and acceptance criteria.
- **UX Expert**: Propose a simple, user-friendly UI design.
- **Orchestrator / Master**: Coordinate all roles and consolidate documents and source code.

---

## Deliverables

- React source code (including components).
- `Dockerfile` and `docker-compose.yml`.
- `README.md`.
- Test case documentation.

---

## Additional Instructions

- Produce the output in phases:
  1. Requirement analysis
  2. Architecture design
  3. Code and deployment files
  4. Test documentation
- At each phase provide a brief explanation and key file contents.
- Finally, give startup commands (for example: `docker-compose up --build`) and the expected URL to access the application.
