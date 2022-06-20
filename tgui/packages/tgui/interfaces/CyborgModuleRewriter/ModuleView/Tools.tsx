/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { SFC } from 'inferno';
import { Button } from '../../../components';
import { EmptyPlaceholder } from '../EmptyPlaceholder';
import * as styles from '../style';
import { ToolData } from '../type';

interface ToolProps {
  onMoveToolDown: () => void,
  onMoveToolUp: () => void,
  onRemoveTool: () => void,
  onPickTool: () => void,
  onInsertTool: () => void,
}

const Tool: SFC<ToolProps> = props => {
  const {
    children,
    onMoveToolDown,
    onMoveToolUp,
    onRemoveTool,
    onPickTool,
    onInsertTool,
  } = props;
  return (
    <div>
      <Button icon="arrow-up" onClick={onMoveToolUp} title="Move Up" />
      <Button icon="arrow-down" onClick={onMoveToolDown} title="Move Down" />
      <Button icon="trash" onClick={onRemoveTool} title="Remove" />
      <Button icon="cut" onClick={onPickTool} title="Pick" />
      <Button icon="paste" onClick={onInsertTool} title="Insert" />
      <span className={styles.ToolLabel}>{children}</span>
    </div>
  );
};

interface ToolsProps {
  onMoveToolDown: (toolRef: string) => void,
  onMoveToolUp: (toolRef: string) => void,
  onRemoveTool: (toolRef: string) => void,
  onPickTool: (toolRef: string) => void,
  onInsertTool: (toolRef: string) => void,
  tools: Array<ToolData>
}

export const Tools: SFC<ToolsProps> = props => {
  const {
    onMoveToolDown,
    onMoveToolUp,
    onRemoveTool,
    onPickTool,
    onInsertTool,
    tools = [],
  } = props;
  return (
    <div>
      {
        tools.length > 0
          ? tools.map(tool => {
            const {
              name,
              ref: toolRef,
            } = tool;
            return (
              <Tool
                onMoveToolDown={() => onMoveToolDown(toolRef)}
                onMoveToolUp={() => onMoveToolUp(toolRef)}
                onRemoveTool={() => onRemoveTool(toolRef)}
                onPickTool={() => onPickTool(toolRef)}
                onInsertTool={() => onInsertTool(toolRef)}
                key={toolRef}
              >
                {name}
              </Tool>
            );
          })
          : <EmptyPlaceholder>Module has no tools</EmptyPlaceholder>
      }
    </div>
  );
};
